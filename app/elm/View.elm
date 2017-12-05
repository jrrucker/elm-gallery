module View exposing (..)

import Http
import Images.Models exposing (Image, Person)
import Images.CardView exposing (cardView)
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


galleryView : List Image -> Html msg
galleryView images =
    div
        [ class "gallery" ]
        (images
            |> List.map (cardView)
        )


imageNotFoundView : Html msg
imageNotFoundView =
    (notFoundView "Image not found.")


personNotFoundView : Html msg
personNotFoundView =
    (notFoundView "Person not found.")


notFoundView : String -> Html msg
notFoundView msg =
    div []
        [ text msg ]



-- Helpers


getImage : Int -> List Image -> Maybe Image
getImage id images =
    images
        |> List.filter (\image -> image.id == id)
        |> List.head


getPerson : Int -> List Person -> Maybe Person
getPerson id allPeople =
    allPeople
        |> List.filter (\person -> person.id == id)
        |> List.head


getPeople : Image -> List Person -> List Person
getPeople image allPeople =
    List.filter (\person -> (List.member person.id image.people)) allPeople


getImagesOfPerson : Person -> List Image -> List Image
getImagesOfPerson person allImages =
    List.filter (\image -> (List.member person.id image.people)) allImages
