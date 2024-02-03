export default async (request, context) => {
  let url = new URL(request.url);
  let x = url.searchParams.get('q')

  const joke = await fetch(x, {
    "headers": {
      "Accept": "application/json"
    }
  });
  
  const jsonData = await joke.json();
  return Response.json(jsonData);
};

export const config = { path: "/get" };
