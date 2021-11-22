import { async_post_request, getTodayDate } from './utils.js'

$(document).ready(async function() {
    // Set default hire date to today for ease of use
    var now = new Date();
    var day = ("0" + now.getDate()).slice(-2);
    var month = ("0" + (now.getMonth() + 1)).slice(-2);
    var today = now.getFullYear()+"-"+(month)+"-"+(day) ;

    $("#hire_date").val(today);

    // document.getElementById("hire_date").valueAsDate = new Date()

    await add_lib_sys_change_listener();
    await add_is_employee_change_listener();
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


async function add_is_employee_change_listener()
{
    return await $("#is_employee").change(async function () {
        const is_checked = document.getElementById('is_employee').checked;

        // Hide employee fields for non-employees
        const hide_fields = is_checked == true ? false : true;
        const employee_fields = document.getElementById("employee-fields");
        employee_fields.hidden = hide_fields;
        return true;
    });
}

