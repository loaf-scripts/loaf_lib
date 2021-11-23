// CRED: https://github.com/TerbSEC/FiveM-CoordsSaver/blob/master/html/init.js
function copyText(content) {
    var element = document.createElement("textarea");
    var selection = document.getSelection();

    element.textContent = content;
    document.body.appendChild(element);
    selection.removeAllRanges();
    element.select();
    document.execCommand("copy");
    selection.removeAllRanges();
    document.body.removeChild(element);
}