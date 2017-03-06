'use strict';

// Change this to a larger number if you want to wait longer.
let waitFactor = 1.0;

// The wait times in milliseconds
let timings =  {
	layerUpload : 4500 * waitFactor,
	layerCreate : 3000 * waitFactor,
	newLayer: 4500 * waitFactor,
	metadata_load: 3000 * waitFactor,
	search: 1000 * waitFactor,
	composer_tour_modal: 1000 * waitFactor
};

module.exports = timings;
