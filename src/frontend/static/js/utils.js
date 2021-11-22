/**
 * @brief Useful utility functions that can be used in many other files
 */

/**
 * @brief Useful function - abstracts async post requests (they get repetative)
 * @param {string} url URL the post request is going to
 * @param {JSON} data_json What is the data to send to the post request
 */
 export async function async_post_request(url, data_json) {
    let res = null;
    try{
        res = await $.post({
            url: url,
            data: JSON.stringify(data_json),
            contentType: 'application/json',

        });
    }catch (error){
        console.log("Post request for url " + url + ' failed');
        console.log(JSON.stringify(error));
        res = 'err';
        return res;
    }

    // try parsing (what should be) a json
    try{
        return JSON.parse(res);
    }catch (error){
        // In this case, we did not receive a valid json
        return res;
    }
}

export function getTodayDate()
{
    // Ref: https://stackoverflow.com/a/52802548/14810215 
    // toISOString is used to get it in the right format required by the input field
    const today = new Date().toISOString().split('T')[0]
    return(today);
}