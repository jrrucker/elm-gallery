module Images.ImageView exposing (imageView)

import Html exposing (Html, div, img, text, p, strong, span, a)
import Html.Attributes exposing (src, alt, title, class, href)
import Images.Models exposing (Image, Person)
import Routing exposing (personPath)


imageView : Image -> List Person -> Html msg
imageView image people =
    div [ class "image-details" ]
        [ renderImage image
        , renderImageDescription image
        , renderPeopleList people
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
            personPath person.id
    in
        a
            [ href path ]
            [ text person.name ]
