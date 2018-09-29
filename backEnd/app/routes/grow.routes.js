module.exports = (app) => {
    const grow = require('../controllers/grow.controller.js');

    // Add no. of produce
    app.get('/grow', function (req,res) {
        function getRandomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min;
        }
        console.log("hello");
        res.status(200).send({
            message: getRandomInt(1,1000)
        });

    });

}