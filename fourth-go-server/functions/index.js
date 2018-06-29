const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

admin.initializeApp();

exports.login = functions.https.onRequest((req, res) => {
    if (req.body) {
        let session = {
            login: req.body,
            logout: ""
        };
    
        admin.database().ref('/sessions')
            .push(session)
            .then(() => {
                return cors(req, res, () => {
                    res.send('Logged in!');
                });
            })
            .catch(() => {
                return cors(req, res, () => {
                    res.send(400, 'Error!')
                });
            });
    }
});

exports.logout = functions.https.onRequest((req, res) => {
    if(req.body) {
        admin.database().ref('/sessions')
        .orderByKey()
        .limitToLast(1)
        .once('child_added', (snapshot) => {
            snapshot.ref.update({
                logout: req.body
            });
        })
        .then(() => {
            return cors(req, res, () => {
                res.send('Logged out!');
            });
        })
        .catch(() => {
            return cors(req, res, () => {
                res.send(400, 'Error!')
            });
        });
    }
});