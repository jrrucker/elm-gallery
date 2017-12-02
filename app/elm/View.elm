module View exposing (..)

import Http
import Models exposing (..)
import Routing
import Messages exposing (Msg)
import Images.Models exposing (Image, Person)
import Images.CardView exposing (cardView)
import Images.ImageView exposing (imageView)
import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)


view : Model -> Html Msg
view model =
    div []
        [ page model ]


remoteDataView : (data -> Html Msg) -> WebData data -> Html Msg
remoteDataView subview data =
    case data of
        RemoteData.NotAsked ->
            loadingView

        RemoteData.Loading ->
            loadingView

        RemoteData.Success model ->
            subview model

        RemoteData.Failure err ->
            errorView err


page : Model -> Html Msg
page model =
    case model.route of
        Routing.ImageRoute id ->
            (getImage model id)
                |> remoteDataView
                    (\maybeImage ->
                        case maybeImage of
                            Just image ->
                                (getPeople model image)
                                    |> remoteDataView (imageView image)

                            Nothing ->
                                imageNotFoundView
                    )

        Routing.PersonRoute id ->
            (getPerson model id)
                |> remoteDataView
                    (\maybePerson ->
                        case maybePerson of
                            Just person ->
                                model.allImages
                                    |> RemoteData.map (getImagesOfPerson person)
                                    |> remoteDataView galleryView

                            Nothing ->
                                personNotFoundView
                    )

        Routing.HomeRoute ->
            remoteDataView galleryView model.allImages

        Routing.PersonNotFound ->
            personNotFoundView

        Routing.ImageNotFound ->
            imageNotFoundView

        Routing.NotFoundRoute ->
            (notFoundView "Page not found")


loadingView : Html Msg
loadingView =
    div
        [ class "loading" ]
        [ text "Loading image data... " ]


errorView : Http.Error -> Html Msg
errorView err =
    div
        [ class "error" ]
        [ text ("There was an error... " ++ (toString err)) ]


galleryView : List Image -> Html Msg
galleryView images =
    div
        [ class "gallery" ]
        (images
            |> List.map (cardView)
        )


imageNotFoundView : Html Msg
imageNotFoundView =
    (notFoundView "Image not found.")


personNotFoundView : Html Msg
personNotFoundView =
    (notFoundView "Person not found.")


notFoundView : String -> Html Msg
notFoundView msg =
    div []
        [ text msg ]



-- Helpers


getImage : Model -> Int -> WebData (Maybe Image)
getImage model id =
    model.allImages
        |> RemoteData.map (List.filter (\image -> image.id == id))
        |> RemoteData.map (List.head)


getPerson : Model -> Int -> WebData (Maybe Person)
getPerson model id =
    model.allPeople
        |> RemoteData.map (List.filter (\person -> person.id == id))
        |> RemoteData.map (List.head)


getPeople : Model -> Image -> WebData (List Person)
getPeople model image =
    model.allPeople
        |> RemoteData.map (List.filter (\person -> (List.member person.id image.people)))


getImagesOfPerson : Person -> List Image -> List Image
getImagesOfPerson person images =
    List.filter (\image -> (List.member person.id image.people)) images
