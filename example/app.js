// ****************************************************************************************************************
// ****************************************************************************************************************
// GUI setup

var win = Ti.UI.createWindow({
	backgroundColor: '#fff'
}),
toolbar = Ti.UI.createView({
	width: Ti.UI.FILL, height: Ti.UI.SIZE,
	top: 0, left: 0,
	backgroundImage: 'images/MessageEntryBackground.png',
	backgroundTopCap: 20
}),
textField = require('net.iamyellow.tigrowingtextfield').createView({
	// layout, as any other view
	height: 40, // 40 is the minimum
	left: 10, right: 10,
	// growing / shrink
	minNumberOfLines: 1, // default = 1
	maxNumberOfLines: 10, // default = 3,
	showKeyboardImmediately: true,
	// background
	backgroundImage: 'images/MessageEntryInputField.png',
	backgroundLeftCap: 12,
	backgroundTopCap: 20,
	value: 'hellow',
	// appearance 
	appearance: Ti.UI.KEYBOARD_APPEARANCE_ALERT,
	// text
	autocorrect: false,
	textAlign: 'left',
	font: {
		fontFamily: 'Georgia',
		fontSize: 12
	},
	color: '#333333'
});

toolbar.add(textField);
win.add(toolbar);

// ****************************************************************************************************************
// ****************************************************************************************************************
// events

win.addEventListener('click', function () {
	textField.blur();
});

textField.addEventListener('focus', function (ev) {
	Ti.API.info('////////////////////////////////////////////////////////////');
	Ti.API.info('** focused');
});

textField.addEventListener('change', function (ev) {
	Ti.API.info('////////////////////////////////////////////////////////////');
	Ti.API.info('my value is: ' + ev.value);
	Ti.API.info('my height is: ' + ev.height);
});

textField.addEventListener('blur', function (ev) {
	Ti.API.info('////////////////////////////////////////////////////////////');
	Ti.API.info('** blurred');
});

// ****************************************************************************************************************
// ****************************************************************************************************************
// some value change test

setTimeout(function () {
	textField.value += ' yellow!';
}, 3000);


// ****************************************************************************************************************
// ****************************************************************************************************************
// the show

win.open();