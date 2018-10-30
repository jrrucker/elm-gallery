module Images.GalleryView exposing (galleryView, personGallery)

import Html exposing (Html, div, a, img, text)
import Html.Attributes exposing (class, href, src, alt, title)
import Routing exposing (Route(..), pathFor)
import Images.Models exposing (..)
import Images.Utils exposing (..)


personGallery : PersonId -> List Image -> Html msg
personGallery personId images =
    images
        |> List.map (cardView (Just personId))
        |> buildGalleryView


galleryView : Maybe PersonId -> Album -> Html msg
galleryView maybePersonId album =
    case maybePersonId of
        Just personId ->
            case (getPerson personId album.people) of
                Just person ->
                    (getImagesOfPerson personId album.images)
                        |> List.map (cardView maybePersonId)
                        |> buildGalleryView

                Nothing ->
                    notFoundView

        Nothing ->
            album.images
                |> List.map (cardView Maybe.Nothing)
                |> buildGalleryView


buildGalleryView : List (Html msg) -> Html msg
buildGalleryView cards =
    div
        [ class "gallery" ]
        cards


cardView : Maybe PersonId -> Image -> Html msg
cardView maybePersonId image =
    let
        path =
            maybePersonId
                |> Maybe.map (PersonImageRoute image.id)
                |> Maybe.withDefault (ImageRoute image.id)
    in
        a
            [ class "view-image"
            , href (pathFor path)
            ]
            [ renderThumbnail image ]


renderThumbnail : Image -> Html msg
renderThumbnail image =
    div [ class "image" ]
        [ img
            [ src image.thumbnail
            , alt image.description
            , title image.description
            ]
            []
        ]


notFoundView : Html msg
notFoundView =
    div []
        [ text "Page not found." ]
