#! /usr/bin/env node

const path = require('path');
const fs = require('fs-extra');
const sizeOf = require('image-size');

const imageFolder = process.argv[2];
const imageFolderPath = path.join(__dirname, '../public', imageFolder);
const photosFile = path.join(imageFolderPath, 'images.json');
const peopleFile = path.join(imageFolderPath, 'people.json');

if (!fs.existsSync(imageFolderPath)) {
    console.error('ERROR: Invalid image folder: ', imageFolderPath);
    process.exit(1);
}

function parseAlbum(callback) {
    const files = fs.readdirSync(imageFolderPath);
    const data = files
        .filter((url) => {
            return (url.endsWith('.jpg') || url.endsWith('.png'));
        })
        .map((name, idx) => {
            let imgPath = path.join(imageFolderPath, name);
            let {width, height} = sizeOf(imgPath);
            let url = imageFolder + "/" + name;
            let people = [];

            return {
                id: idx,
                description: "",
                dateAdded: "2017-11-01",
                thumbnail: url,
                fullsize: url,
                download: url,
                people: people,
                width: width,
                height: height
            };
        });

    callback({ images: data });
}

parseAlbum((data) => {
    const photosOutput = JSON.stringify(data, null, 2);
    const peopleOutput = JSON.stringify({ people: [] }, null, 2);
    fs.writeFileSync(photosFile, photosOutput);
    fs.writeFileSync(peopleFile, peopleOutput);
    console.log("JSON files saved to folder: ", imageFolder);
    process.exit(0);
});