module Page.Person exposing (Model, init, setLayout, view)

import Html exposing (Html, div, text)
import Images.JustifiedView exposing (justifiedView)
import Images.Models exposing (Album, Layout, PersonId)
import Images.Utils exposing (getImagesOfPerson)
import Interop exposing (OutMessage(..))
import Routing


type Model
    = AwaitingLayout PersonId
    | Loaded PersonId Layout


init : Album -> PersonId -> ( Model, Cmd msg )
init album personId =
    ( AwaitingLayout personId
    , Interop.send (PersonGalleryDetails (getImagesOfPerson personId album.images))
    )


setLayout : Model -> Layout -> Model
setLayout model layout =
    case model of
        AwaitingLayout personId ->
            Loaded personId layout

        Loaded _ _ ->
            model


view : Album -> Model -> Html msg
view album model =
    case model of
        AwaitingLayout personId ->
            div [] [ text "SHOULDN'T HAPPEN" ]

        Loaded personId layout ->
            justifiedView
                (Routing.PersonImageRoute personId)
                (getImagesOfPerson personId album.images)
                layout
