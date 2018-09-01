module Images.Models exposing (Album, Image, ImageId, ImagesContainerModel, ImgLayout, Layout, Person, PersonId)

import Time exposing (Posix)



-- Types


type alias ImageId =
    Int


type alias PersonId =
    Int


type alias Image =
    { id : ImageId
    , description : String
    , dateAdded : Posix
    , thumbnail : String
    , fullsize : String
    , download : String
    , people : List PersonId
    , width : Int
    , height : Int
    }


type alias Person =
    { id : PersonId
    , name : String
    }


type alias ImagesContainerModel =
    { images : List Image }


type alias Album =
    { images : List Image
    , people : List Person
    }


type alias Layout =
    { containerHeight : Float
    , widowCount : Int
    , boxes : List ImgLayout
    }


type alias ImgLayout =
    { aspectRatio : Float
    , top : Float
    , left : Float
    , width : Float
    , height : Float
    }
