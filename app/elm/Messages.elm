module Messages exposing (..)

import Navigation exposing (Location)
import Images.Models exposing (Image, Person)
import RemoteData exposing (WebData)


type Msg
    = OnLocationChange Location
    | OnLoadImages (WebData (List Image))
    | OnLoadPeople (WebData (List Person))
