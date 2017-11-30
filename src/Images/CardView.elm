module Images.CardView exposing (cardView)

import Html exposing (Html, div, img, text, a)
import Html.Attributes exposing (src, href, alt, title, class)
import Images.Models exposing (Image)
import Routing exposing (imagePath)


cardView : Image -> Html msg
cardView image =
    let
        path =
            imagePath image.id
    in
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
