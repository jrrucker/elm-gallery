module Images.ImageView exposing (imageView)

import Html exposing (Html, div, img, text, p, strong, span, a)
import Html.Attributes exposing (src, alt, title, class, href)
import Images.Models exposing (..)
import Images.Utils exposing (..)
import Routing exposing (Route(..), pathFor)


type NavDirection
    = Previous
    | Next


imageView : Maybe PersonId -> ImageId -> ( List Image, List Person ) -> Html msg
imageView maybePersonId imageId ( allImages, allPeople ) =
    case (getImage imageId allImages) of
        Just image ->
            let
                people =
                    getPeople image allPeople
            in
                case maybePersonId of
                    Just personId ->
                        let
                            personHasImage =
                                List.member personId image.people

                            imagesInGallery =
                                getImagesOfPerson personId allImages

                            maybePerson =
                                getPerson personId allPeople
                        in
                            if (personHasImage) then
                                buildImageView
                                    image
                                    imagesInGallery
                                    maybePerson
                                    people
                            else
                                notFoundView

                    Nothing ->
                        buildImageView
                            image
                            allImages
                            Maybe.Nothing
                            people

        Nothing ->
            notFoundView



-- getImagesInGallery : Maybe PersonId -> List Image -> List Image
-- getImagesInGallery maybePersonId allImages =
--     case maybePersonId of
--         Just personId ->
--             getImagesOfPerson personId allImages
--         Nothing ->
--             allImages


buildImageView : Image -> List Image -> Maybe Person -> List Person -> Html msg
buildImageView image imagesInGallery maybePerson people =
    div [ class "image-view" ]
        [ renderImage image
        , renderImageDescription image
        , renderPeopleList people
        , renderImageNav image imagesInGallery maybePerson
        ]


renderImage : Image -> Html msg
renderImage image =
    img
        [ src image.fullsize
        , alt image.description
        , title image.description
        ]
        []


renderImageDescription : Image -> Html msg
renderImageDescription image =
    p []
        [ text image.description ]


renderPeopleList : List Person -> Html msg
renderPeopleList people =
    p [ class "people" ]
        [ strong []
            [ text "People: " ]
        , span []
            (people
                |> List.map (renderPerson)
            )
        ]


renderPerson : Person -> Html msg
renderPerson person =
    let
        path =
            pathFor (PersonRoute person.id)
    in
        a
            [ href path ]
            [ text person.name ]


prevImage : Image -> List Image -> Maybe Image
prevImage image gallery =
    gallery
        |> List.filter (\img -> (img.id < image.id))
        |> List.reverse
        |> List.head


nextImage : Image -> List Image -> Maybe Image
nextImage image gallery =
    gallery
        |> List.filter (\img -> (img.id > image.id))
        |> List.head


renderImageNavLink : Maybe Image -> Maybe Person -> NavDirection -> Html msg
renderImageNavLink maybeImage maybePerson direction =
    case maybeImage of
        Just image ->
            renderImageLink image maybePerson direction

        Nothing ->
            text "No more images."


renderImageNav : Image -> List Image -> Maybe Person -> Html msg
renderImageNav image gallery maybePerson =
    div [ class "image-nav" ]
        [ renderImageNavLink (prevImage image gallery) maybePerson Previous
        , renderImageNavLink (nextImage image gallery) maybePerson Next
        ]


renderImageLink : Image -> Maybe Person -> NavDirection -> Html msg
renderImageLink image maybePerson direction =
    let
        directionStr =
            direction
                |> toString
                |> String.toLower
    in
        case maybePerson of
            Just person ->
                a
                    [ href (pathFor (PersonImageRoute image.id person.id))
                    , class directionStr
                    ]
                    [ text directionStr ]

            Nothing ->
                a
                    [ href (pathFor (ImageRoute image.id))
                    , class directionStr
                    ]
                    [ text directionStr ]


notFoundView : Html msg
notFoundView =
    div []
        [ text "Page not found." ]
