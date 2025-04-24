extends Node


# Define algorithms and their settings
var algorithms = {
	"gaussian_blur": {
		"num_params": 1,
		"parameters": [{
			"param": "sigma", # Which param will be changed by the slider
			"min_value": 0.0, # Min value for the slider
			"max_value": 8.0, # Max value for the slider
			"default_value": 0.0, # Default value for the slider
		}]
	},
	"contrast": {
		"num_params": 4,
		"parameters": [{
			"param": "multiplier",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			},
			{
			"param": "skew_red",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			},
			{
			"param": "skew_green",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			},
			{
			"param": "skew_blue",
			"min_value": 0.0,
			"max_value": 5.0,
			"default_value": 1.0,
			}]
	},
	"noise": {
		"num_params": 2,
		"parameters": [{
			"param": "noise_intensity",
			"min_value": 0.0,
			"max_value": 1.0,
			"default_value": 0.0,
		},
		{
			"param": "seed",
			"min_value": 0.0,
			"max_value": 1000.0,
			"default_value": 0.0,
		}]
	},
	"brightness": {
		"num_params": 4,
		"parameters": [{
			"param": "adjustment",
			"min_value": -1.0,
			"max_value": 1.0,
			"default_value": 0.0,
			},
			{
			"param": "skew_red",
			"min_value": -1.0,
			"max_value": 1.0,
			"default_value": 0.0,
			},
			{
			"param": "skew_green",
			"min_value": -1.0,
			"max_value": 1.0,
			"default_value": 0.0,
			},
			{
			"param": "skew_blue",
			"min_value": -1.0,
			"max_value": 1.0,
			"default_value": 0.0,
			}]
	},
	"thresholding": {
		"num_params": 3,
		"parameters": [{
			"param": "red_threshold",
			"min_value": 0.0,
			"max_value": 100.0,
			"default_value": 50.0
		},
		{
			"param": "green_threshold",
			"min_value": 0.0,
			"max_value": 100.0,
			"default_value": 50.0
		},
		{
			"param": "blue_threshold",
			"min_value": 0.0,
			"max_value": 100.0,
			"default_value": 50.0
		}]
	},
	"image_negative": {
		"num_params": 0,
		"parameters": []
	},
	"log_transform": {
		"num_params": 1,
		"parameters": [{
			"param": "scaling_constant",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		}]
	},
	"power_law": {
		"num_params": 2,
		"parameters": [{
			"param": "gamma",
			"min_value": 0.01,
			"max_value": 5.00,
			"default_value": 1.0
		},
		{
			"param": "scaling_constant",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		}]
	},
	"contrast_stretching": {
		"num_params": 4,
		"parameters": [{
			"param": "input_lower_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 0
		},
		{
			"param": "input_upper_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 255
		},
		{
			"param": "output_lower_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 0.00
		},
		{
			"param": "output_upper_bound",
			"min_value": 0.00,
			"max_value": 255.00,
			"default_value": 255.0
		}
		]
	},
	"unsharp_masking": {
		"num_params": 1,
		"parameters": [{
			"param": "sigma", # Which param will be changed by the slider
			"min_value": 0.0, # Min value for the slider
			"max_value": 8.0, # Max value for the slider
			"default_value": 0.0, # Default value for the slider
		}]
	},
	"highboost_filtering": {
		"num_params": 1,
		"parameters": [{
			"param": "sigma", # Which param will be changed by the slider
			"min_value": 0.0, # Min value for the slider
			"max_value": 8.0, # Max value for the slider
			"default_value": 0.0, # Default value for the slider
		},
		{
			"param": "mask_contribution", # Which param will be changed by the slider
			"min_value": 0.0, # Min value for the slider
			"max_value": 5.0, # Max value for the slider
			"default_value": 1.0, # Default value for the slider
		}]
	},
}