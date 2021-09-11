
Sooner or later, every configuration format
turns into a programming/scripting language (not Smalltalk, but Ruby or HyperTalk):

* variables
* functions
* loops
* etc.

Let's use user-submitted CSS as an example:

Do you want to
allow your users to submit SASS/LESS/etc.? Or let them
submit the output of SASSS/LESS/etc. compilers while
you validate the final CSS? In this case, stick with
CSS as a configuration format instead of a implementing
a scripting language (ie SASS, LESS, etc.) that
produces CSS.

There is a valid reason for this: Sooner or later
you will want to create your own alternative.
But, the focus shall always be first on validating
CSS content rather then create a SASS alternative.

Users will most likely be attracted to the
most widely used alternative that is evolving and outpacing
your efforts.

Another reason to focus on configuration instead of programming/scripting:
CSS and HTML, despite evolving efforts will stay mostly the same.
It would be best to first implement a safe/strict subset
while your users enjoy choosing their own ways to generate the
CSS.

The majority of people will still just use templates and avoid
taking advantage of the other features. If they do take advantage
of the functionality beyond variables, it would most likely lead
to infinite loops and wasted CPU and RAM.

The Majority wants brain-dead/psychi customization. It's only a Tiny Minority
that is creative and smart to utilize the extra functionality.
They are also smart enough to use JS and other languages (e.g. Crystal).
So this creates a false dichotomy that useful: The ones that want
Psychic Customization vs the ones that want to create Universes.
Focusing on these two helps you later implement features
for the ones in the middle. (Inspired from "Objectified" documentary.)
In this case, focusing on The Majority fulfills the needs of
The Minority: Validating just HTML and CSS does not prevent
The Minority from creativity. In fact, the "right limitations" lead to more
creativity.


