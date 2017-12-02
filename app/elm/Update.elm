module Update exposing (..)

import Routing exposing (parseLocation)
import Messages exposing (Msg)
import Models exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Messages.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        Messages.OnLoadImages response ->
            ( { model | allImages = response }, Cmd.none )

        Messages.OnLoadPeople response ->
            ( { model | allPeople = response }, Cmd.none )
