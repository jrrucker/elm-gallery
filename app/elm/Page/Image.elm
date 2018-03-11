module Page.Image exposing (Model, view, init)

import Html exposing (Html, text)
import Images.Models exposing (ImageId, Album)
import Images.ImageView exposing (imageView)


type alias Model =
    { imageId : ImageId
    }


init : ImageId -> ( Model, Cmd msg )
init imgId =
    ( Model imgId, Cmd.none )


view : Album -> Model -> Html msg
view album model =
    imageView Nothing model.imageId album
