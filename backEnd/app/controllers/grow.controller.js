const Grow = require('../models/grow.model.js');

// Grow and Save a new produce
exports.random = (req, res) => {
    console.log("hello")
    // Validate request
   //* if(!req.body.grow) {
        //return res.status(400).send({
          //  message: "Produce can not be empty"
       // })

    function getRandomArbitrary(min, max) {
        return Math.random() * (max - min) + min;
    }

    /**
     * Returns a random integer between min (inclusive) and max (inclusive)
     * Using Math.round() will give you a non-uniform distribution!
     */
    function getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    res.status(200).send({
        message: getRandomInt(1,1000)
    });
    }