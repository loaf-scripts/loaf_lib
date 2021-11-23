window.addEventListener("message", function(event) {
    switch (event.data.type) {
        case "convert_base64":
            sendBase64Server(event.data);
            break;
        case "copy_text":
            copyText(event.data.content);
            break;
        default: 
            console.log(`${event.data.type} is not a valid event`);
            break;
    }
});