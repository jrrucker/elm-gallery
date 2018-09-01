module Images.JustifiedView exposing (justifiedView)

import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (class, href, src, style)
import Images.Models exposing (Image, ImageId, ImgLayout, Layout)
import Routing exposing (Route)


justifiedView : (ImageId -> Route) -> List Image -> Layout -> Html msg
justifiedView routeGen images layout =
    let
        imagesWithLayout =
            List.map2 (\a b -> ( a, b )) images layout.boxes
    in
    div
        [ class "justified-gallery"
        , style "height" (px layout.containerHeight)
        ]
        (List.map (layoutImageView routeGen) imagesWithLayout)


layoutImageView : (ImageId -> Route) -> ( Image, ImgLayout ) -> Html msg
layoutImageView routeGen ( image, layout ) =
    a
        [ class "justified-image"
        , href (Routing.pathFor (routeGen image.id))
        , style "width" (px layout.width)
        , style "height" (px layout.height)
        , style "left" (px layout.left)
        , style "top" (px layout.top)
        ]
        [ img [ src image.fullsize ] []
        ]


px : Float -> String
px amount =
    String.fromFloat amount ++ "px"
