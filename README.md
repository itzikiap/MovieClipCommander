# MovieClipCommander
ActionScript framework to overcome AS2 movieclip inheritence by composition

## History
Back in the days of action script 2 programming, adding extra functionality to movieclip was a pain. This framework is written to overcome this problem by using composition, much like angularjs is now using directives for dom elements.

This framework served me well for my as2 projects. I would like to think that it is not useless now, and I hope some of the concepts in it will inspire other projects.

## From the Documentation:
MovieClipCommander Framework is a system of classes for quick and easy management and handling of events and extensions for MovieClips.

The MovieClipCommander (MCC) keeps reference to a designated MovieClip along a corresponding hierarchy structure. Thus making it able to be extended, without actually extend the MovieClip class.

#### The Framework allows:

    Extending the abilities and behaviors of the MovieClip keeping its structure and the original MovieClip class untouched (preserving its identity).
    One main system for quick and easy event management allowing central and organized registration of events. Thus also solving the scope problems related to registering callback function to listen to MovieClip events.
    Organized, extensions based Framework allowing a real OOP code management in Flash ActionScript 2.0. 

#### 3 Tier based Framework:

##### First layer: The “Wrapper”.

This class constitutes the main core of the Framework.
MovieClipWrapper keeps the reference to the designated MovieClip and its corresponding hierarchy structure.

##### Second layer: The Events Management.

    public function handleEvent(evt:Object) {
    …
    }

As the name implies, this class is responsible for central and organized registration and management of events.
MovieClipEvents keeps delegates and allows a more robust managing and dispatching of events.

##### Third layer: The Application Layer:

This layer is the interface that binds it all to a Framework.
Its compound of two parts; The Commander and the Service:

    var MCC:MovieClipCommander = new MovieClipCommander(mc);
    MCC.registerExtention(“ease”, Ease);
    MCC.addEventListener(“easeDone”, this);
    MCC.addClipEvent(“onEnterFrame”, this);

Using the MovieClipCommander it is possible to manage behaviors of MovieClips as easy as managing extensions.

    class iap.commander.extentions.*** extends MovieClipService{
    …
    }

Every behavior registered to an MCC is a service.
MovieClipService is an implementation of the Service interface.
To create an extension that expands the MovieClip’s abilities, the MovieClipService needs to be extended.

## More
You can read more in this old blog:
https://iapstuff.wordpress.com/movieclipcommander/
