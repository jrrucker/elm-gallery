module Page.Home exposing (Model, init, setLayout, view)

import Html exposing (Html, div, text)
import Images.JustifiedView exposing (justifiedView)
import Images.Models exposing (Album, Layout)
import Interop exposing (OutMessage(..))
import Routing


type Model
    = AwaitingLayout
    | Loaded Layout


init : Album -> ( Model, Cmd msg )
init album =
    ( AwaitingLayout, Interop.send (HomeGalleryDetails album.images) )


setLayout : Model -> Layout -> Model
setLayout model layout =
    Loaded layout


view : Album -> Model -> Html msg
view album model =
    case model of
        AwaitingLayout ->
            div [] [ text "Computing layout..." ]

        Loaded layout ->
            justifiedView Routing.ImageRoute album.images layout
