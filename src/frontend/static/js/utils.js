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
    // Inspired by https://stackoverflow.com/a/12347050/14810215
    // the time might not be right based on the time zone
    const now = new Date();
    const day = ("0" + now.getDate()).slice(-2);
    const month = ("0" + (now.getMonth() + 1)).slice(-2);
    const today = now.getFullYear()+"-"+(month)+"-"+(day) ;
    return(today);
}