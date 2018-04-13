var request = require('request');
var needle = require('needle');
var cheerio = require('cheerio');

function get_data_needle() {
  var URL = 'https://liquimoly.ru/item/1920.html';

  needle.get(URL, function(error, response) {
    if (error) throw error;
    const $ = cheerio.load(response.body);
    const art = $('.item_card strong').text();
    console.log(art);

    // console.log($('strong').text());
    // return $('h1').text();
  });
}

get_data_needle();
