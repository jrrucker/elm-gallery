module Images.GalleryView exposing (galleryView)

import Html exposing (Html, div, a, img, text)
import Html.Attributes exposing (class, href, src, alt, title)
import Routing exposing (imagePath, personPath, personImagePath)
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
    case maybePersonId of
        Just personId ->
            buildCardView
                (personImagePath image.id personId)
                image

        Nothing ->
            buildCardView
                (imagePath image.id)
                image


buildCardView : String -> Image -> Html msg
buildCardView path image =
    a
        [ class "view-image"
        , href path
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
