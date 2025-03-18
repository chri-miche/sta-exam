const log = console.log;
const warn = console.warn;
const error = console.error;

/*
NB: this modelling is doable (in a surely easier and more easy-to-read way) with rxjs
*/

/**
 * A mailbox is a data structure as follows:
 * - it holds the messages for the current communication round;
 * - it holds a {@link Promise} that will resolve when the queue is full;
 * - when the Promise is initialised, the internal _resolve function is linked to the resolve function of the promise;
 * - when promise is resolved, the queue must be emptied.
 */
class Mailbox {

    constructor() {
        this._init();
    }

    _init() {
        this.messages = [];
        this.receive = new Promise(resolve => {
            this._resolve = (messages) => {
                resolve(messages);
            };
        });
    }

    addMessage(message) {
        this.messages.push(message);
    }

    flush() {
        this._resolve(this.messages.filter(message => message != null));
        this._init();
    }

    toString() {
        return `Mailbox {messages=${this.messages}}`;
    }

}

/**
 * A node in a distributed network represents a computer (or processor) that
 * operates in parallel as others. It has:
 * - an id (as we are in the LOCAL model);
 * - a flag `stopped` that signals when it is stopped;
 * - a {@link Mailbox} to handle communication;
 * - a list of neighbours, that must be set on the outside;
 * - an `invoke` function, that represents a single loop in the distributed algorithm.
 * 
 * The `invoke` function is defined outside, when the algorithm is chosen to be run on a network.
 * When the node is stopped, through the `stop` method, the `invoke` function becomes a function
 * that communicate nothing to neighbours.
 */
class Node {

    constructor(id, properties) {
        this.id = id;
        this.stopped = false;
        this.mailbox = new Mailbox();
        if (properties) {
            this.properties = properties;
        }
        this.neighbours = [];
    }

    stop() {
        this.stopped = true;
        this.invoke = async () => {
            await broadcast(this, null);
            // discard result
        }
    }

    toString() {
        return `Node {id=${this.id}; stopped=${this.stopped}}`;
    }
}

/**
 * The function `send` is the central point of communication in the runtime.
 * It is also responsible to check if a targeted mailbox is full and,
 * if so, to flush it.
 */
function send(message, recipient) {
    log(`Sending message ${message} to recipient ${recipient}`)
    const mailbox = recipient.mailbox;
    mailbox.addMessage(message);
    log(`Mailbox ${recipient.id} is ${mailbox}`)
    const neighbours = recipient.neighbours;
    if (mailbox.messages.length === neighbours.length) {
        log(`Node ${recipient} will now receive non null messages. Emptying mailbox...`)
        mailbox.flush();
    } else if (mailbox.messages.length > neighbours.length) {
        console.error("Unexpected state: more messages than neighbours");
    }
}

/**
 * Main primitive for synchronized communication rounds.
 * Takes as input the sender node and a dispatch object whose:
 * - keys are the ids of neighbours;
 * - values are the messages to send to the corresponding key.
 * 
 * This function ensures two main invariants:
 * 1. all neighbours of a node will receive exactly one message from the sender in this communication round;
 * 2. the sender won't progress until it has received a message from all neighbours.
 */
async function communicate(sender, dispatch) {
    if (Object.keys(dispatch).length < sender.neighbours.length) {
        warn(`The sender ${sender} tried to dispatch messages to some but not all of its neighbours. 
            I'm assuming that the inteded behaviour is to send a null message to all of the others`);
    }
    const recipients = sender.neighbours;
    log(`Sender ${sender} sends message ${dispatch} to neighbours: recipients=${recipients}`)
    for (const recipient of recipients) {
        send(dispatch[recipient.id] || null, recipient);
    }
    const messages = await sender.mailbox.receive;
    return messages;
}

/**
 * Utility function to broadcast a message to all neighbours.
 */
function broadcast(sender, message) {
    const dispatch = {};
    for (const neighbour of sender.neighbours) {
        dispatch[neighbour.id] = message;
    }
    return communicate(sender, dispatch);
}

/**
 * Runs an algorithm on a network.
 * 
 * First of all, updates the `invoke` function on all nodes.
 * Then it sets up the main loop:
 * - before the loop, all nodes are running;
 * - in each iteration
 */
async function run(algorithm, nodes) {
    for (const node of nodes) {
        node.invoke = () => algorithm(node);
    }
    const nullMode = [];
    const nullCycle = () => {
        setTimeout(async () => {
            await Promise.all(nullMode.map(async node => {
                log(`Start null invoke ${node}`)
                await node.invoke();
                log(`End null invoke ${node}`)
            }));
            if (nodes.some(node => !node.stopped)) {
                nullCycle();
            } else {
                log('End of null mode. Quitting...')
            }
        })
    }
    nullCycle();
    const rounds = await Promise.all(nodes.map(async node => {
        let count = 0;
        while (!node.stopped) {
            count++;
            await node.invoke();
        }
        log(`Initialised null mode for ${node}`)
        nullMode.push(node);
        // await node.invoke(); // TODO not good! ci possono essere più invocazioni 
        return count;
    }));
    log('Total number of rounds is', Math.max(...rounds))
    log('Result is: ', nodes)
}
