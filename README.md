# Ruby on Rails: Replacing Model Attributes
Ever have a Rails model and start adding a bunch of attributes and realize after a while that you had a poor design pattern, but now have hundreds or thousands of values in your production database? What the hell do you do then?
I had a similar problem in a project where we were defining different user permissions with booleans in our ```User``` model, but it was becoming clunky.
