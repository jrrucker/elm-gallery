module View exposing (errorView, loadingView)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Http


loadingView : Html msg
loadingView =
    div
        [ class "loading" ]
        [ text "Loading image data... " ]


errorView : Http.Error -> Html msg
errorView err =
    div
        [ class "error" ]
        [ text "There was an error... " ]
