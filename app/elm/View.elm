module View exposing (..)

import Http
import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)


remoteDataView : (a -> Html msg) -> WebData a -> Html msg
remoteDataView subview webData =
    case webData of
        RemoteData.NotAsked ->
            loadingView

        RemoteData.Loading ->
            loadingView

        RemoteData.Success data ->
            subview data

        RemoteData.Failure err ->
            errorView err


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
