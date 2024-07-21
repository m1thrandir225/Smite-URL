import Toast from "./toast.js";

/**
 *
 * @param {HTMLElement} container
 */
function clearContainer(container) {
  const childLinks = container.getElementsByClassName("linkNode");

  Array.from(childLinks).forEach((el) => {
    container.removeChild(el);
  });
}
/**
 *
 * @param {HTMLDivElement} container
 * @param {HTMLElement} element
 */
function appendElementToContainer(container, element) {
  container.appendChild(element);
}
/**
 *
 * @param {String} shortCode
 * @returns {String}
 */
function composeShortLink(shortCode) {
  return window.location.href + shortCode;
}
/**
 *
 * @param {String} content
 */
function copyToClipboard(content) {
  navigator.clipboard.writeText(content);
}

document.addEventListener("DOMContentLoaded", () => {
  const urlInput = document.getElementById("initialURL");
  const submitButton = document.getElementById("createURLButton");
  const form = document.getElementById("createURLForm");
  const resultContainer = document.getElementById("result");

  if (!urlInput || !submitButton || !form || !resultContainer) {
    throw new Error("Required DOM nodes missing.");
  }

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const formValues = Object.fromEntries(formData);

    const initialURL = formValues.initialURL;

    if (!initialURL) {
      throw new Error("There was an error with the form submission.");
    }

    const requestData = JSON.stringify({
      url: initialURL.toString(),
    });

    const response = await fetch("/api/urls", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: requestData,
    });

    if (!response.ok) {
      throw new Error("There was an error during your request.");
    }

    const data = await response.json();

    const shortCode = data.shortURL;

    const redirectLink = composeShortLink(shortCode);

    resultContainer.classList.remove("hidden");

    clearContainer(resultContainer);

    const linkNode = document.createElement("a");

    linkNode.textContent = redirectLink;

    linkNode.classList =
      "linkNode text-lg font-bold text-cyan-600 hover:text-xl hover:text-cyan-700 transition-all ease-in-out duration-100";

    linkNode.setAttribute("href", redirectLink);

    appendElementToContainer(resultContainer, linkNode);

    copyToClipboard(redirectLink);

    Toast("Link copied to your clipboard");

    form.reset();
  });
});
