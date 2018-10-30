let layout = require('justified-layout');


function handleElmMessage(message) {
    switch (message.type) {
        case 'GalleryDetails':
        return messageFor(message.responseType,
                          layout(message.data,
                          {
                              containerWidth: window.innerWidth,
                              containerPadding: 5,
                              boxSpacing: 5
                          }));
            break;
        default:
            console.log(`Unknown message of type: ${message.type}.`, message);
    }
}

function messageFor(msgType, data) {
    return {
        type: msgType,
        data: data
    };
}

module.exports = handleElmMessage;
