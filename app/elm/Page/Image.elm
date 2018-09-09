module Page.Image exposing (Model, init, view)

import Html exposing (Html, text)
import Images.ImageView exposing (imageView)
import Images.Models exposing (Album, ImageId)


type alias Model =
    { imageId : ImageId
    }


init : ImageId -> ( Model, Cmd msg )
init imgId =
    ( Model imgId, Cmd.none )


view : Album -> Model -> Html msg
view album model =
    imageView Nothing model.imageId album
