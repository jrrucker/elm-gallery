module View exposing (..)

import Http
import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)


loadingView : Html msg
loadingView =
    div
        [ class "loading" ]
        [ text "Loading image data... " ]


errorView : Http.Error -> Html msg
errorView err =
    div
        [ class "error" ]
        [ text ("There was an error... " ++ (toString err)) ]
