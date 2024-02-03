import { Elm } from "./Main.elm";

async function init() {
    let data = {
        user: "",
        password: ""
    };

    try {
        const credentials = await navigator.credentials.get({ password: true });
        data.user = credentials.id;
        data.password = credentials.password;
    } catch (e) {
        console.log(e);
    }

    Elm.Main.init({ flags: data });
}

init();
