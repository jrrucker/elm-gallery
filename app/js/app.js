import { Elm } from '../elm/Main.elm';
import helpers from './elmHelpers.js';

let app = Elm.Main.init();

app.ports.toJs.subscribe((msg) => {
    console.log('From Elm:', msg);
    let result = helpers(msg);
    console.log('To Elm:', helpers(msg));
    if (result) {
        app.ports.fromJs.send(result);
    }
});
        

