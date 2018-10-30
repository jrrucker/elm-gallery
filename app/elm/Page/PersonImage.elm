module Page.PersonImage exposing (Model, view, init)

import Html exposing (Html, text)
import Images.Models exposing (ImageId, PersonId, Album)
import Images.ImageView exposing (imageView)


type alias Model =
    { imageId : ImageId
    , personId : PersonId
    }


init : ImageId -> PersonId -> ( Model, Cmd msg )
init imgId personId =
    ( Model imgId personId, Cmd.none )


view : Album -> Model -> Html msg
view album model =
    imageView (Just model.personId) model.imageId album
