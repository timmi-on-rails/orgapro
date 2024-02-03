export default async (request, context) => {
  const url = new URL(request.url);
  const x = url.searchParams.get('q')
  const body = await request.json();

  const joke = await fetch(x, {
    "method": "POST",
    "headers": {
      "Accept": "application/json",
      "Content-Type": "application/json"
    },
    "body": JSON.stringify(body)
  });
  
  const jsonData = await joke.json();
  return Response.json(jsonData);
};

export const config = { path: "/post" };
