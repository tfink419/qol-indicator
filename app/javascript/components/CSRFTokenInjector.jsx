import React from "react";
import { getCsrf } from '../fetch'

export default () => {
  const CSRF_TOKEN = getCsrf()

  return (
    <React.Fragment>
      { CSRF_TOKEN &&
        <input type="hidden" name="authenticity_token" value={CSRF_TOKEN}/>
      }
    </React.Fragment>
)};