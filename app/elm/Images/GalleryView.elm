module Images.GalleryView exposing (galleryView)

import Html exposing (Html, div, a, img, text)
import Html.Attributes exposing (class, href, src, alt, title)
import Routing exposing (Route(..), pathFor)
import Images.Models exposing (..)
import Images.Utils exposing (..)


galleryView : Maybe PersonId -> ( List Image, List Person ) -> Html msg
galleryView maybePersonId ( allImages, allPeople ) =
    case maybePersonId of
        Just personId ->
            case (getPerson personId allPeople) of
                Just person ->
                    (getImagesOfPerson personId allImages)
                        |> List.map (cardView maybePersonId)
                        |> buildGalleryView

                Nothing ->
                    notFoundView

        Nothing ->
            allImages
                |> List.map (cardView Maybe.Nothing)
                |> buildGalleryView


buildGalleryView : List (Html msg) -> Html msg
buildGalleryView cards =
    div
        [ class "gallery-view" ]
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
