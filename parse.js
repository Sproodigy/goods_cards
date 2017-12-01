var needle = require('needle');

var URL = 'https://webref.ru/css/font-size/';

needle.get(URL, function (err, res, body) {
    if (err) throw err;
    console.log(body);
    console.log(res.statusCode);
});
