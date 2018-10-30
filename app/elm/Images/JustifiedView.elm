module Images.JustifiedView exposing (justifiedView)

import Html exposing (Html, div, text, img, a)
import Images.Models exposing (Image, Layout, ImgLayout, ImageId)
import Html.Attributes exposing (style, src, class, href)
import Routing exposing (Route)


justifiedView : (ImageId -> Route) -> List Image -> Layout -> Html msg
justifiedView routeGen images layout =
    let
        imagesWithLayout =
            List.map2 (,) images layout.boxes
    in
        div
            [ class "justified-gallery"
            , style [ ( "height", px layout.containerHeight ) ]
            ]
            (List.map (layoutImageView routeGen) imagesWithLayout)


layoutImageView : (ImageId -> Route) -> ( Image, ImgLayout ) -> Html msg
layoutImageView routeGen ( image, layout ) =
    a
        [ class "justified-image"
        , href (Routing.pathFor (routeGen image.id))
        , style
            [ ( "width", px layout.width )
            , ( "height", px layout.height )
            , ( "left", px layout.left )
            , ( "top", px layout.top )
            ]
        ]
        [ img [ src image.fullsize ] []
        ]


px : Float -> String
px amount =
    (toString amount) ++ "px"
