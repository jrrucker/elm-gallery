module Images.Models exposing (..)

import Date exposing (Date)


-- Types


type alias ImageId =
    Int


type alias PersonId =
    Int


type alias Image =
    { id : ImageId
    , description : String
    , dateAdded : Date
    , thumbnail : String
    , fullsize : String
    , download : String
    , people : List PersonId
    }


type alias Person =
    { id : PersonId
    , name : String
    }


type alias ImagesContainerModel =
    { images : List Image }
