const log = console.log;
const warn = console.warn;
const error = console.error;

/**
 * The main data structure of a distributed network / graph. A node
 * has the following properties:
 * - the id, since we are in the LOCAL model;
 * - a flag telling whether the node is stopped;
 * - a mailbox, representing a list of messages;
 * - a list of neighbours;
 * - a promise meant to notify the scheduler that the node is yielding;
 * - a promise meant to notify the "node thread" that the node can resume;
 * - a whole bunch of promises.
 */
class Node {

    constructor(id, properties) {
        this.id = id;
        this.stopped = false;
        this.mailbox = [];
        this.neighbours = [];
        this.yielding = new Promise(resolve => {
            this._yield = resolve;
        });
        this.resumed = new Promise(resolve => {
            this._resume = resolve;
        });
        if (properties) {
            this.properties = properties;
        }
    }

    /**
     * A stopped node doesn't take anymore part in the communications, however
     * it's equivalent as sending null messages. To avoid concurrency problem
     * while checking the mailbox to be full, we model it this way.
     */
    stop() {
        this.stopped = true;
        this.invoke = async () => {
            await broadcast(this, null);
            // discard result
        }
    }

    /** Restart a node with a new invoke function. */
    restart(invoke) {
        this.stopped = false;
        this.invoke = invoke;
    }

    /**
     * A node yielding has to do two things:
     * 1. notify the runtime that the yielding promise is resolved;
     * 2. resets the `resumed` promise with a new one.
     * 
     * Notice that point 2. is safe as the `resumed` promise is
     * already satisfied when the node is yielding.
     */
    yield() {
        this._yield();
        this.resumed = new Promise(resolve => {
            this._resume = resolve;
        });
    }

    /**
     * A node resuming has to do two things:
     * 1. notify the "thread" that it is going to resume;
     * 2. resets the `yielding` promise with a new one.
     * 
     * Notice that point 2. is safe as the `yielding` promise is
     * already satisfied when the node is running.
     */
    resume(messages) {
        this._resume(messages);
        this.yielding = new Promise(resolve => {
            this._yield = resolve;
        });
    }

    toString() {
        return `Node {id=${this.id}; stopped=${this.stopped}}`;
    }
}

/**
 * This function is the point where all communications happen.
 * There are two invariants that it ensures:
 * 1. when a node sends a message, it sends messages to all neighbours;
 * 2. after a node sends a message, it yields control to the runtime.
 * 
 * This ensures that if all nodes arrive at this point in the code,
 * any awaiting node is going to be satisfied with all messages.
 * 
 * Moreover, it ensures that communication rounds are really synchronous
 * as the model prescribes.
 * 
 * When the runtime resumes a node, it will provide this promise with
 * the messages that were in the node's mailbox.
 * 
 * @param {@link Node} sender the node that is sending the messages
 * @param {@link Object} dispatch a map [node.id => message]
 * @returns a promise that resolves the messages
 */
async function communicate(sender, dispatch) {
    if (Object.keys(dispatch).length < sender.neighbours.length) {
        warn(`The sender ${sender} tried to dispatch messages to some but not all of its neighbours. 
            I'm assuming that the inteded behaviour is to send a null message to all of the others`);
    }
    const recipients = sender.neighbours;
    log(`Sender ${sender} sends message ${dispatch} to neighbours: recipients=${recipients}`)
    for (const recipient of recipients) {
        const mail = {
            header: {
                sender: sender.id
            },
            body: dispatch[recipient.id] ?? null
        }
        recipient.mailbox.push(mail);
    }
    // time to cede control to runtime
    // yes honey..
    log(`[COMMUNICATE] ${sender} is yielding`)
    sender.yield();
    const messages = await sender.resumed;
    log(`[COMMUNICATE] ${sender} is going to resume! messages received are=${messages}`)
    return messages;
}

/**
 * An utility function wrapped around {@link communicate}
 * 
 * @param {@link Node} sender the node that is going to send the message
 * @param {any} message the message to broadcast
 * @returns a promise that resolves when the communication round closes
 */
function broadcast(sender, message) {
    const dispatch = {};
    for (const neighbour of sender.neighbours) {
        dispatch[neighbour.id] = message;
    }
    return communicate(sender, dispatch);
}

/**
 * Awaits for all nodes as parameter to yield. Flushes all of their mailboxes and resumes the nodes.
 * 
 * @param {@link Node[]} nodes 
 */
async function flushMessages(nodes) {

    await Promise.all(nodes.map(async node => {
        log(`[FLUSH MESSAGES] awaiting for ${node} to yield`)
        await node.yielding;
        log(`[FLUSH MESSAGES] ${node} yielded`)
    }));

    log(`[FLUSH MESSAGES] All nodes yielded, emptying mailboxes and resuming`)
    for (const node of nodes) {
        const tmp = node.mailbox;
        node.mailbox = [];
        node.resume(tmp);
    }
}

const {BehaviorSubject, filter, take, firstValueFrom} = rxjs;
log(`fvf!!`, firstValueFrom);

/**
 * The main function to run an algorithm on a distributed network
 * 
 * @param {@link Promise} algorithm a function that takes a node and returns a promise that resolves when the algorithm for a single node finishes
 * @param {@link Node[]} nodes a list of nodes to run the algorithm
 */
async function run(algorithm, nodes, options = {}) {

    const roundTimeout = options['roundTimeout'] ?? 1000;
    const applyStyle = options['applyStyle'] ?? (() => {});
    const pauseBehavior = options['pauseBehavior'] ?? new BehaviorSubject(false); // default, never paused
    const onPlay = pauseBehavior.pipe(
        filter(isPaused => !isPaused),
        take(1)
    );
    

    log('Init')
    const toResume = [];
    for (const node of nodes) {
        // setting stopped to false; setting invoke function
        node.restart(async () => {
            log(`[INVOKE] Invoking ${node}`)
            await algorithm(node);
            log(`[INVOKE] End of ${node}`)
        });
        toResume.push(node);
    }

    /** 
     * The main loop works as follows:
     * 1. it is a promise that resolves when all nodes are stopped;
     * 2. if some node is still running at the end of the algorithm,
     *    it will schedule another iteration in JS's runtime task queue.
     * 
     * Note that point 2 heavily relies on how JS's runtime works:
     * - when mailboxes are flushed, the awaiting promises in nodes 
     *   will resolve, scheduling a microtask: this means that nodes
     *   algorithms will be executed before the next iteration with
     *   setTimout (for it schedules a macrotask);
     * - if a node ends its algorithm body (invoke) it will run the
     *   toResume push before the main loop starts again;
     * - if a node yields, JS's runtime will suspend its "thread" until
     *   the next mailbox flush.
     * 
    */
    const loop = new Promise(resolve => {
        const iteration = async (count) => {
            log(`[MAIN LOOP] Enter loop ${count}. Invoking ${toResume}`)
            while (toResume.length > 0) {
                const node = toResume.pop();
                node.invoke().then(() => {
                    log(`[INVOKE APPEND] marking ${node} toResume`)
                    toResume.push(node);
                }); // no await
            }
            log(`[MAIN LOOP] Checking pause`)
            // onplay is a BehaviourSubject, hence it emits once right after it is subscribed
            // it emits only once and then unsubscribes (take(1))
            await firstValueFrom(onPlay);
            log(`[MAIN LOOP] Resumed all. Flushing messages in a while`)
            await flushMessages(nodes);
            log(`[MAIN LOOP] Flushed all messages`)
            for (const node of nodes) {
                applyStyle(node);
            }
            if (nodes.some(node => !node.stopped)) {
                setTimeout(() => {
                    iteration(count + 1);
                }, roundTimeout);
            } else {
                // wrapped in set timeout to await for all invokes to finish
                // not necessary, but more ordered
                setTimeout(() => {
                    resolve(count);
                });
            }
        }
        iteration(0);
    })
    const count = await loop;
    log(`[MAIN LOOP OUT] Number of loops was ${count}`);
    return count;
}
