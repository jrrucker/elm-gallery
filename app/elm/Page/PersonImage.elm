module Page.PersonImage exposing (Model, init, view)

import Html exposing (Html, text)
import Images.ImageView exposing (imageView)
import Images.Models exposing (Album, ImageId, PersonId)


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
