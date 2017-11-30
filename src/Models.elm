module Models exposing (..)

import Images.Models exposing (Image, Person)
import Routing exposing (Route)
import RemoteData exposing (WebData)


type alias Model =
    { route : Route
    , allImages : WebData (List Image)
    , allPeople : WebData (List Person)
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , allImages = RemoteData.Loading
    , allPeople = RemoteData.Loading
    }
