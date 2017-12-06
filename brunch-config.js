module.exports = {
    files: {
        javascripts: {
            joinTo: "elm.js"
        },
        stylesheets: {
            joinTo: "style.css"
        }
    },
    plugins: {
        elm: {
            "exposed-modules": ["Main"],
            renderErrors: true,
            parameters: ["--debug", "--yes", "--warn"]
        },
        sass: {
            options: {
                sourceMapEmbed: true
            }
        }
    },
    overrides: {
        production: {
            plugins: {
                elm: {
                    renderErrors: false,
                    parameters: ["--yes", "--warn"]
                }
            }
        }
    }
};
