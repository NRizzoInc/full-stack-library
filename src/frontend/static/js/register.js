import { async_post_request } from './utils.js'

$(document).ready(async function() {
    await add_lib_sys_change_listener();
});

/**
 * @brief Waits for a user to select a library system.
 * When it happens, sets the library options to those ONLY in the picked system
 */
async function add_lib_sys_change_listener()
{
    return await $("#lib_sys_name").change(async function () {
        // If this is the default option, show ALL libraries
        const lib_sys_id = $(this).val();  // get the selected country ID from the HTML input
        const url = "/register/set_avail_libs/" + (lib_sys_id == "" ? "all_libs" : lib_sys_id);

        // Wait for a selection of library system
        const lib_list = await async_post_request(url, {});
        return await set_library_options(lib_list);
    });
}

/**
 * @brief Sets the options for the library drop down
 * @param {Array{String}} lib_options The libraries that are valid options and should be inserted as options
 */
async function set_library_options(lib_options)
{
    let res = 0;
    const select_object = $("#lib_name");

    // Delete the current options - leave the placeholder
    await $.each(select_object.children(), async function(iter, child){
        if(child.text != ""){
            child.remove();
        }
    });

    // Add options for each of the libraries in the system
    $.each(lib_options, function (iter, lib_option_dict){
        const key = lib_option_dict[0];
        const val = lib_option_dict[1];

        select_object.append($("<option>", {
            value: String(key),
            text: String(val)
        }));
    });

    return res;

}