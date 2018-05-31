#! /usr/bin/env node

const https = require('https');
const http = require('http');
const download = require('download');
const path = require('path');
const fs = require('fs-extra');
const os = require('os');
const sizeOf = require('image-size');

const imgDownloadPath = fs.mkdtempSync(path.join(os.tmpdir(), 'gen-album'));
const albumPath = path.join(__dirname, '../app/assets/gen_album/');
const albumFile = path.join(albumPath, 'images.json');
const peopleSourceFile = path.join(__dirname, '../app/assets/people.json');
const peopleFile = path.join(albumPath, 'people.json');

if (!fs.existsSync(imgDownloadPath)) {
    fs.mkdirSync(imgDownloadPath);
}
fetchImageList((urls) => {
    console.log('Downloading images...');
    Promise.all(urls.map((url) => {
        return download(url, imgDownloadPath);
    })).then(() => {
        fs.copySync(imgDownloadPath, albumPath);
        console.log('Downloads Complete!');
        let albumData = generateAlbum();
        let albumText = JSON.stringify(albumData, null, 2);
        fs.writeFileSync(albumFile, albumText);
        fs.copyFileSync(peopleSourceFile, peopleFile);
        console.log("Album created at http://localhost:3333/?album=gen_album");
        console.log("Brunch rebuild may be needed if images look broken.");
    });
});

function generateAlbum() {
    const files = fs.readdirSync(albumPath);
    let data = files
        .filter((name) => {
            return (name != "images.json" && name != "people.json");
        })
        .map((name, idx) => {
            let imgPath = path.join(albumPath,name);
            let {width, height} = sizeOf(imgPath);
            let url = "gen_album/" + name;
            let people = [1, 2, 3].filter(() => {
                return Math.random() > 0.3;
            });

            return {
                id: idx,
                description: "Image #" + idx,
                dateAdded: "2017-11-01",
                thumbnail: url,
                fullsize: url,
                download: url,
                people: people,
                width: width,
                height: height
            };
    });

    return {images: data};
}

function fetchImageList(callback) {
    https.get('https://www.reddit.com/r/EarthPorn/.json', (res) => {
        handleJsonResponse(res, (json) => {
            let urls = json.data.children
                .map((post) => {
                    return post.data.url;
                })
                .filter((url) => {
                    return (url.endsWith('.jpg') || url.endsWith('.png'));
                });
            callback(urls);
        });
    }).on('error', (e) => {
        throw e;
    });
}


function handleJsonResponse(res, callback) {
    const { statusCode } = res;
    const contentType = res.headers['content-type'];

    let error;
    if (statusCode !== 200) {
        error = new Error('Request Failed.\n' +
                          `Status Code: ${statusCode}`);
    } else if (!/^application\/json/.test(contentType)) {
        error = new Error('Invalid content-type.\n' +
                          `Expected application/json but received ${contentType}`);
    }
    if (error) {
        throw error;
    }

    res.setEncoding('utf8');
    let rawData = '';
    res.on('data', (chunk) => { rawData += chunk; });
    res.on('end', () => {
        try {
            callback(JSON.parse(rawData));
        } catch (e) {
            throw e;
        }
    });
}
