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
		}],
		"description": "Smoothing/blurring filter that convolves the image with weights following a Gaussian distribution."
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
			}],
			"description": "Contrast modifies the RGB values of the image by multiplying them against a fixed value, maintaining their ratio so as to not disrupt the color balance"
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
		}],
		"description": "Adds random noise to the image based on the UV coordinates and the seed value"
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
			}],
			"description": "Brightness works in a similar manner to Contrast, where it modifies the RGB values by a constant amount. However, Brightness maintains the absolute difference between RBG values as opposed to the relative (Or proportional) difference"
	},
	"thresholding_rgb": {
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
		}],
		"description": "Thresholding allows you to map an RGB image into a binary form based on whether or not the individual color channels (Red, Green, and Blue) are above or below the threshold"
	},
	"thresholding": {
		"num_params": 1,
		"parameters": [{
			"param": "threshold",
			"min_value": 0.0,
			"max_value": 255.0,
			"default_value": 255.0/2
		}],
		"description": "Thresholding is an algorithm that converts an n-bit pixel into a one-bit activation map. I.e. black and white"
	},
	"image_negative": {
		"num_params": 0,
		"parameters": [],
		"description": "Image Negative inverts the color channel by subtracting the current color values by the maximum possible. I.e. 255 (8-bit) minus n"
	},
	"log_transform": {
		"num_params": 1,
		"parameters": [{
			"param": "scaling_constant",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		}],
		"description": "Log Transform takes the log^2 of the RGB values multiplied by a scaling constant. It notably enhances dark images",
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
		}],
		"description": "The Power Transform is useful to brighten or darken the image in a non-linear fashion according to a given exponent and a scaling constant"
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
		}],
		"description": "Contrast Stretching applies a piecewise function to essentially compress or expand an RGB range, minimizing the values above and below the thresholds and stretching the color ranges inside the threshold to compensate for the removal of other colors"
	},
	"convolution": {
		"num_params": 3,
		"parameters": [{
			"param": "radius",
			"min_value": 1,
			"max_value": 3,
			"default_value": 1
		},
		{
			"param": "horizontal_skew",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		},
		{
			"param": "vertical_skew",
			"min_value": 0.0,
			"max_value": 2.0,
			"default_value": 1.0
		}],
		"description": "Convolution is a fundamental technique that involves using a Kernel to compare nearby pixels to determine the value of the root pixel"
	},
	"unsharp_masking": {
		"num_params": 1,
		"parameters": [{
			"param": "sigma", # Which param will be changed by the slider
			"min_value": 0.0, # Min value for the slider
			"max_value": 8.0, # Max value for the slider
			"default_value": 0.0, # Default value for the slider
		}],
		"description": "Unsharp Masking creates a blurred version of the original image and uses that as a guide to sharpen the original image further based on how the blurred image compares to the original"
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
		}],
		"description": "Highboost filtering involves boosting the high-frequency components of an image without sacrificing the low-frequency components any more than necessary. It involves preserving and amplifying the high frequency components of the image (Edges, corners) and overwriting the low frequency parts of the image where necessary to boost image fidelity"
	},
}


# Sort algorithms alphabetically
func _ready() -> void:
	var sorted_keys = algorithms.keys()
	sorted_keys.sort()

	var algorithms_sorted = {}
	for key in sorted_keys:
		algorithms_sorted[key] = algorithms[key]
	algorithms = algorithms_sorted
