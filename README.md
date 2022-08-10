# animal-ranges

Utilities for calculating and displaying the range of an animal based on its location data. Includes an optional airtag-based animal tracking setup.

<h1>Calculating Ranges</h1>
The bounds function returns the center and radius of animal's range given a list of Timed structs. You can optionally specify the percentage of the animal's time spent you want covered (it defaults to 0.9 or 90%).

<h1>Plotting Data & Range</h1>
The plotdata function takes in the same arguments as the bounds function but instead of returning range data shows an overlay of the range circle and your data points.

<h1>Airtags</h1>
Included in the repo is a script for tracking an animal using airtags, which can only run on macs. To start it, customize the included constants as directed in the script, and call the track function.
